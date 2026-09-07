--Ｄ－ＨＥＲＯ ドレッドガイ
--Destiny HERO - Dreadmaster
local s,id=GetID()
function s.initial_effect(c)
	--If this card is Special Summoned by "Clock Tower Prison": Destroy all monsters you control, except "Destiny HERO" monsters, also, after that, you can Special Summon up to 2 "Destiny HERO" monsters from your GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re:GetHandler():IsCode(75041269,101402062) end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--After this card is Special Summoned, for the rest of this turn, "Destiny HERO" monsters you control cannot be destroyed, also you take no battle damage when they battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
	--The ATK/DEF of this card are equal to the combined original ATK of all other "Destiny HERO" monsters you control
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_SINGLE)
	e3a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3a:SetCode(EFFECT_SET_ATTACK)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetValue(function(e,c) return Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_DESTINY_HERO),c:GetControler(),LOCATION_MZONE,0,c):GetSum(Card.GetBaseAttack) end)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e3b)
end
s.listed_names={75041269} --"Clock Tower Prison"
s.listed_series={SET_DESTINY_HERO}
function s.desfilter(c)
	return c:IsFacedown() or not c:IsSetCard(SET_DESTINY_HERO)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_DESTINY_HERO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local break_chk=false
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil)
	if #g>0 then
		break_chk=true
		Duel.Destroy(g,REASON_EFFECT)
	end
	local mmz_count=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if mmz_count>0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		mmz_count=math.min(mmz_count,2)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then mmz_count=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,mmz_count,nil,e,tp)
		if #sg>0 then
			if break_chk then Duel.BreakEffect() end
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,2))
	--For the rest of this turn, "Destiny HERO" monsters you control cannot be destroyed, also you take no battle damage when they battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsSetCard(SET_DESTINY_HERO) end)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	Duel.RegisterEffect(e2,tp)
end
