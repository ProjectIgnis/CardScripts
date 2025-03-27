--Ｅｖｉｌ★Ｔｗｉｎ'ｓ トラブル・サニー
--Evil★Twin's Trouble Sunny
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2+ monsters, including an "Evil★Twin" monster
	Link.AddProcedure(c,nil,2,4,s.lcheck)
	--Special Summon up to 1 "Ki-sikil" and "Lil-la" monster each
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(Cost.SelfTribute)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Send 1 card on the field to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.tgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_KI_SIKIL,SET_LIL_LA,SET_EVIL_TWIN}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_EVIL_TWIN,lc,sumtype,tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard({SET_KI_SIKIL,SET_LIL_LA}) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sprescon(sg)
	return sg:FilterCount(Card.IsSetCard,nil,SET_KI_SIKIL)<2 and sg:FilterCount(Card.IsSetCard,nil,SET_LIL_LA)<2
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=math.min(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ft<1 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if #g<1 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.sprescon,1,tp,HINTMSG_SPSUMMON)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.tgcostfilter(c,ct)
	return c:IsSetCard(SET_EVIL_TWIN) and c:IsAbleToGraveAsCost() and c:IsMonster()
		and (not c:IsLocation(LOCATION_MZONE) or (c:IsFaceup() and ct>1))
end
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 and aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0)
		and Duel.IsExistingMatchingCard(s.tgcostfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_MZONE,0,1,nil,#g)
	end
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local cg=Duel.SelectMatchingCard(tp,s.tgcostfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_MZONE,0,1,1,nil,#g)
	Duel.SendtoGrave(cg,REASON_COST)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g,true)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end