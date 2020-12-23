--ツッパリーチ
--Bluffreach
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--normal draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DRAW)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.drcon(0))
	e2:SetTarget(s.drtg(0))
	e2:SetOperation(s.drop(0))
	c:RegisterEffect(e2)
	--effect draw
	local e3=e2:Clone()
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_TOGRAVE)
	e3:SetCondition(s.drcon(1))
	e3:SetTarget(s.drtg(1))
	e3:SetOperation(s.drop(1))
	c:RegisterEffect(e3)
end
function s.drcon(mode)
	return  function(e,tp,eg,ep,ev,re,r,rp)
				if not (ep==tp and eg:IsExists(aux.NOT(Card.IsPublic),1,nil)) then return false end
				if mode==0 then
					return r==REASON_RULE
				else
					return r==REASON_EFFECT
				end
			end
end
function s.drtg(mode)
	return  function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return mode==0 or e:GetHandler():IsAbleToGrave() end
				local g=eg:Filter(aux.NOT(Card.IsPublic),nil)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
				local sg=g:Select(tp,1,1,nil):GetFirst()
				Duel.ConfirmCards(1-tp,sg)
				e:SetLabelObject(sg)
				Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,1,0,0)
				Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
				if mode~=0 then
					Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
				end
			end
end
function s.drop(mode)
	return  function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				local tc=e:GetLabelObject()
				if not (c:IsRelateToEffect(e) and tc and tc:IsLocation(LOCATION_HAND)) then return end
				if mode~=0 then
					if Duel.SendtoGrave(c,REASON_EFFECT)==0 then return end
				end
				if Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 then
					Duel.Draw(tp,1,REASON_EFFECT)
				end
			end
end
