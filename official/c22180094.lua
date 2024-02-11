--Ｓ－Ｆｏｒｃｅ 乱破小夜丸
--S-Force Rappa Chiyomaru
--Scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "S-Force" monster from deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMING_SUMMON|TIMING_SPSUMMON)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.SForceCost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Limit the attacks of monsters in the same column as your "S-Force" monsters
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_SINGLE)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2a:SetValue(s.atlimit)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetLabelObject(e2a)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(aux.SForceTarget)
	c:RegisterEffect(e2)
end
s.listed_series={SET_S_FORCE}
s.listed_names={id}
function s.atlimit(e,c)
	return not e:GetHandler():GetColumnGroup():IsContains(c)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_S_FORCE) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end