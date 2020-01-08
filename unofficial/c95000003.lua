--Darkness/Spell A
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetValue(s.valcon)
	c:RegisterEffect(e2)
	--cannot be negate/disable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_INACTIVATE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(1,0)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DISEFFECT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(1,0)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
	--tohand
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
s.listed_names={95000004,95000005,95000006,95000007,95000008}
s.mark=0
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:GetSequence()<5
end
function s.setfilter(c,code)
	return c:IsSSetable() and c:IsCode(code)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_SZONE)-Duel.GetLocationCount(tp,LOCATION_FZONE)-Duel.GetLocationCount(tp,LOCATION_PZONE))>4
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,95000004) 
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,95000005) 
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,95000006) 
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,95000007) 
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,95000008)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if (Duel.GetLocationCount(tp,LOCATION_SZONE)-Duel.GetLocationCount(tp,LOCATION_FZONE)-Duel.GetLocationCount(tp,LOCATION_PZONE))<=4 then return end
	local g1=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,95000004)
	local g2=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,95000005)
	local g3=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,95000006)
	local g4=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,95000007)
	local g5=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,95000008)
	if #g1>0 and #g2>0 and #g3>0 and #g4>0 and #g5>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINT_SET)
		local sg1=g1:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINT_SET)
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		Duel.Hint(HINT_SELECTMSG,tp,HINT_SET)
		local sg3=g3:Select(tp,1,1,nil)
		sg1:Merge(sg3)
		Duel.Hint(HINT_SELECTMSG,tp,HINT_SET)
		local sg4=g4:Select(tp,1,1,nil)
		sg1:Merge(sg4)
		Duel.Hint(HINT_SELECTMSG,tp,HINT_SET)
		local sg5=g5:Select(tp,1,1,nil)
		sg1:Merge(sg5)
		local tc=sg1:GetFirst()
		while tc do
			Duel.SSet(tp,tc)
			tc=sg1:GetNext()
		end
	end
end
function s.valcon(e,re,r,rp)
	return (r&REASON_EFFECT)~=0
end
function s.indtg(e,c)
	return c:IsFaceup() and c:GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
function s.efilter(e,ct)
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	local tc=te:GetHandler()
	return tc:GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
function s.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end 
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
