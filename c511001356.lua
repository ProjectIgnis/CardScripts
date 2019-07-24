--Hero's Guild
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--send to grave
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(id)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(5851097,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(id+1)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.IsPlayerCanDiscardDeck(1-tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or not Duel.IsPlayerCanDiscardDeck(tp,1) or not Duel.IsPlayerCanDiscardDeck(1-tp,1) then return end
	local tc1=Duel.GetDecktopGroup(tp,1):GetFirst()
	local tc2=Duel.GetDecktopGroup(1-tp,1):GetFirst()
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
	local v=0
	if tc1 and tc1:IsRace(RACE_WARRIOR) and tc1:IsLocation(LOCATION_GRAVE) and tc1:IsAbleToHand() and Duel.SelectYesNo(tp,aux.Stringid(4179255,0)) then
		v=v+1
	end
	if tc2 and tc2:IsRace(RACE_WARRIOR) and tc2:IsLocation(LOCATION_GRAVE) and tc1:IsAbleToHand() and Duel.SelectYesNo(1-tp,aux.Stringid(4179255,0)) then
		v=v+2
	end
	if v==0 then return end
	local p=0
	local g=nil
	if v==1 then
		g=tc1
		p=tc1:GetControler()
	elseif v==2 then
		g=tc2
		p=tc2:GetControler()
	else
		g=Group.FromCards(tc1,tc2)
		p=PLAYER_ALL
	end
	Duel.RaiseEvent(g,id,e,REASON_EFFECT,tp,p,v)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain()==0 then return true end
	for i=1,Duel.GetCurrentChain() do
		local te=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT)
		local tc=te:GetHandler()
		if tc~=e:GetHandler() and tc:IsControler(tp) and tc:IsOriginalCode(id) then
			return false
		end
	end
	return true
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,#eg,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=eg:Filter(Card.IsRelateToEffect,nil,e)
	if #g<=0 then return end
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
	Duel.ConfirmCards(tp,g)
	Duel.RaiseSingleEvent(e:GetHandler(),id+1,e,0,tp,0,0)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_ACTIVATED)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsRelateToEffect(e) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Destroy(c,REASON_EFFECT)
	end
end
