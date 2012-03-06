# -*- encoding : utf-8 -*-

Mailer.delivery_method[:type] = :sendmail

Mailer.credentials[:from] = 'ondrej@bartas.cz'
Mailer.credentials[:subject] = "Password reset"
Mailer.credentials[:body] = "Someone hopefully you, requested password rest"
