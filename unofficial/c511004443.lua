--Vulcan Dragni the Cubic King (movie)
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Inflict effect damage
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(s.target0)
	e2:SetOperation(s.operation0)
	c:RegisterEffect(e2)
	--ATK increase
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SET_BASE_ATTACK)
	e3:SetValue(function (e) return 800*e:GetHandler():GetOverlayGroup():FilterCount(Card.IsMonster,nil) end)
	c:RegisterEffect(e3)
	--Add to hand when destroying a monster by battle
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLED)
	e4:SetTarget(s.target1)
	e4:SetOperation(s.operation1)
	c:RegisterEffect(e4)
end
s.listed_names={3775068}
function s.condition(e,tp,eg,ev,ep,re,r,rp)
	return Duel.IsTurnPlayer(tp)
end
function s.filter(c,sc)
	return c:IsMonster() and c:IsCubicSeed() and c:IsFaceup()
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,2,nil,e:GetHandler()) and e:GetHandler():IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,true,false) end
	local tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,2,2,nil,e:GetHandler())
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
function s.target0(e,tp,eg,ev,ep,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,800)
end
function s.operation0(e,tp,eg,ev,ep,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
function s.filter1(c)
	return c:IsAbleToHand() and c:IsCode(3775068)
end
function s.target1(e,tp,eg,ev,ep,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,true,false) and c:IsMonster() and c:IsCubicSeed()
end
function s.operation1(e,tp,eg,ev,ep,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetOverlayGroup()
	if Duel.SendtoDeck(c,nil,0,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tg=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil)
		if tg and #tg>0 then Duel.SendtoHand(tg,nil,REASON_EFFECT) end
		local count=#mg
		mg=mg:Filter(s.spfilter,nil,e,tp)
		if #mg<count then return end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<#mg or (Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and #mg>1) then return end
		Duel.SpecialSummon(mg,SUMMON_TYPE_SPECIAL,tp,tp,true,false,POS_FACEUP)
	end
end