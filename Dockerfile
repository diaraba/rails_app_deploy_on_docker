# Fait correspondre la version Ruby à 3.0.1, qui est la version du texte
FROM ruby:3.0.1

# Installe les clés et le référentiel de Yarn
RUN wget --quiet -O - /tmp/pubkey.gpg https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
# Met à jour les paquets et installe Node.js, le client PostgreSQL et Yarn
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client yarn

# Installez Node.js 12.x depuis les sources officielles
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

# Crée le répertoire /notes_app
RUN mkdir /notes_app
WORKDIR /notes_app

# Copie les fichiers Gemfile et Gemfile.lock
COPY Gemfile /notes_app/Gemfile
COPY Gemfile.lock /notes_app/Gemfile.lock

# Exécute la commande bundle install pour installer les gems
RUN bundle install

# Copie tout le contenu local vers le répertoire /notes_app
COPY . /notes_app

# Copie le script entrypoint.sh et le rend exécutable
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

# Définit le point d'entrée de l'image avec entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Expose le port 3000
EXPOSE 3000

# Exécute la commande "rails server -b 0.0.0.0" au démarrage du conteneur
CMD ["rails", "server", "-b", "0.0.0.0"]
