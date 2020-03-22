--電磁石の戦士マグネット・ベルセリオン
--Berserkion the Electromagna Warrior
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
s.listed_series={0x2066}
s.listed_names={42023223,79418928,15502037}
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(s.cchk1,1,nil,sg)
end
function s.cchk1(c,sg)
	return c:IsCode(42023223) and sg:IsExists(s.cchk2,1,nil,sg)
end
function s.cchk2(c,sg)
	return c:IsCode(79418928) and sg:FilterCount(s.cchk3,c)==1
end
function s.cchk3(c)
	return c:IsCode(15502037)
end
function s.cfilter(c,code)
	return c:IsCode(code) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,true)
end
function s.spcon(e,c)
	local c=e:GetHandler()
	if c==nil then return true end
	local tp=c:GetControler()
	local rg1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,c,42023223)
	local rg2=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,c,79418928)
	local rg3=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,c,15502037)
	local rg=rg1:Clone()
	rg:Merge(rg2)
	rg:Merge(rg3)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and #rg1>0 and #rg2>0 and #rg3>0 
		and aux.SelectUnselectGroup(rg,e,tp,3,3,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,c,42023223)
	rg:Merge(Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,c,79418928))
	rg:Merge(Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,c,15502037))
	local g=aux.SelectUnselectGroup(rg,e,tp,3,3,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end
function s.costfilter(c)
	return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0x2066) or c:IsCode(99785935,39256679,11549357)) and c:IsLevelBelow(4) and c:IsAbleToRemoveAsCost() 
		and aux.SpElimFilter(c,true)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp~=tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
function s.spfilter(c,e,tp,code)
	return c:IsFaceup() and c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp,42023223)
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp,79418928)
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp,15502037)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp,42023223)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp,79418928)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g3=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp,15502037)
	g1:Merge(g2)
	g1:Merge(g3)
	Duel.SetTargetCard(g1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,3,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.GetTargetCards(e)
	if ft<=0 or #g==0 or #g>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if #g<=ft then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,ft,ft,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:Sub(sg)
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
