--胡蝶姉妹
--Phalaenop Sisters
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 Level 7 or higher Insect or Plant monster from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetCost(Cost.SelfTribute)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	return g1:GetSum(Card.GetLevel)<=g2:GetSum(Card.GetLevel)
end
function s.thfilter(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_INSECT|RACE_PLANT) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,2700)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if sc then
		Duel.SendtoHand(sc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sc)
		local c=e:GetHandler()
		local code=sc:GetOriginalCodeRule()
		--Register if the player Normal or Special Summons the added monster or a card with the same original name
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetCountLimit(1)
		e1:SetCondition(function(e,tp,eg,ep) return ep==tp and ((eg:IsContains(sc) and sc:IsFaceup()) or eg:IsExists(aux.FaceupFilter(Card.IsOriginalCodeRule,code),1,nil)) end)
		e1:SetOperation(function(e) e:SetLabel(1) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(e2,tp)
		--During the End Phase of this turn, take 2700 damage if you did not Normal or Special Summon the added monster, or a card with the same original name
		local e3=e1:Clone()
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCondition(function() return e1:GetLabel()==0 and e2:GetLabel()==0 end)
		e3:SetOperation(function(e,tp) Duel.Damage(tp,2700,REASON_EFFECT) end)
		Duel.RegisterEffect(e3,tp)
		aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,1))
	end
end