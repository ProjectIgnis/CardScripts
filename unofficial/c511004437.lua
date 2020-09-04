--Dark Garnex the Cubic Beast (Movie)
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Change ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetValue(function (e) return 1000*e:GetHandler():GetOverlayGroup():FilterCount(Card.IsType,nil,TYPE_MONSTER) end)
	c:RegisterEffect(e2)
	--Add to hand when destroying a monster by battle
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetTarget(s.target0)
	e3:SetOperation(s.operation0)
	c:RegisterEffect(e3)
end
s.listed_names={78509901}
function s.filter(c,sc)
	return c:IsType(TYPE_MONSTER) and c:IsCubicSeed() and c:IsFaceup()
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil,e:GetHandler()) and e:GetHandler():IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,true,false) end
	local tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e:GetHandler())
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ev,ep,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	if c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,true,false) and tg and #tg>0 then
		local mg=tg:Clone()
		local tc=tg:GetFirst()
		while tc do
			if tc:GetOverlayCount()~=0 then Duel.SendtoGrave(tc:GetOverlayGroup(),REASON_RULE) end
			tc=tg:GetNext()
		end
		c:SetMaterial(mg)
		Duel.Overlay(c,mg)
		Duel.SpecialSummon(c,SUMMON_TYPE_SPECIAL,tp,tp,true,false,POS_FACEUP)
	end
end
function s.filter1(c)
	return c:IsAbleToHand() and c:IsCode(78509901)
end
function s.target0(e,tp,eg,ev,ep,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,true,false) and c:IsType(TYPE_MONSTER) and c:IsCubicSeed()
end
function s.operation0(e,tp,eg,ev,ep,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetOverlayGroup()
	if Duel.SendtoDeck(c,nil,0,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)
		local tg=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil)
		if tg and #tg>0 then Duel.SendtoHand(tg,nil,REASON_EFFECT) end
		local count=#mg
		mg=mg:Filter(s.spfilter,nil,e,tp)
		if #mg<count then return end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<#mg or (Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and #mg>1) then return end
		Duel.SpecialSummon(mg,SUMMON_TYPE_SPECIAL,tp,tp,true,false,POS_FACEUP)
	end
end
