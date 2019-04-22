--Final Light
local s, id = GetID()
function s.initial_effect(c)
	--activate
	local e1 = Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	for _,te in ipairs({Duel.GetPlayerEffect(tp,EFFECT_LPCOST_CHANGE)}) do
		local val=te:GetValue()
		if val(te,e,tp,1000)~=1000 then return false end
	end
	return true
end
function s.filter1(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x122) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeEffectTarget(e)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk == 0 then
		e:SetLabel(10)
		return true
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g = Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE,0,nil,e,tp)
	local fg = g:GetClassCount(Card.GetCode)
	local ft = Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return false end
	if chk == 0 then
		if e:GetLabel() ~= 10 then return false end
		return ft > 0 and #g > 0 and Duel.CheckLPCost(tp,1000)
	end
	local n = Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and 1 or math.min(fg,ft)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local pay_list = {}
	for p = 1, n do
		if Duel.CheckLPCost(tp,1000*p) then table.insert(pay_list, p) end
	end
	local pay = Duel.AnnounceNumber(tp,table.unpack(pay_list))
	Duel.PayLPCost(tp,pay*1000)
	local sg = aux.SelectUnselectGroup(g,e,tp,pay,pay,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,#sg,sg,tp,0)
end
function s.filter2(c,e,sp)
	return c:IsAttackBelow(2000) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g1, ft1 = Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e), Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft1 <= 0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft1 = 1 end
	local sg = g1
	if #g1 > ft1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		sg = g1:Select(tp,ft1,ft1,nil)
	end
	local count = Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	if count > 0 then
		local g2, ft2 = Duel.GetMatchingGroup(s.filter2,tp,0,LOCATION_GRAVE,nil,e,1-tp), math.min(Duel.GetLocationCount(1-tp,LOCATION_MZONE),count)		
		if #g2 > 0 and ft2 > 0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			if Duel.IsPlayerAffectedByEffect(1-tp,CARD_BLUEEYES_SPIRIT) then ft2 = 1 end
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
			sg = g2:Select(1-tp,1,ft2,nil)
			Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
