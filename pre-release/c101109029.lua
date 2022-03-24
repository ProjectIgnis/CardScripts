-- クローラー・ソゥマ
-- Krawler Suma
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Change position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	-- Reduce level
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
s.listed_series={0x104}
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsCanTurnSet() end
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingTarget(aux.FilterFaceupFunction(Card.IsCanTurnSet),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,CATEGORY_POSITION)
	local g=Duel.SelectTarget(tp,aux.FilterFaceupFunction(Card.IsCanTurnSet),tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		and tc:IsRelateToEffect(e) and tc:IsFaceup()
		and Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)>0 then
		-- Cannot change its battle position
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3313)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		tc:RegisterEffect(e1)
	end
end
function s.lvfilter(c,e,tp)
	return c:HasLevel() and c:IsSetCard(0x104) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
function s.lvrescon(mustlv)
	return function(sg)
		local sum=sg:GetSum(Card.GetLevel)
		return sum==mustlv and aux.dncheck(sg)
	end
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft==0 or not c:HasLevel() or c:IsLevelBelow(2) then return false end
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		if c:IsLevelAbove(3) and aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(2),0) then return true end
		if c:IsLevelAbove(5) and aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(4),0) then return true end
		return false
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft==0 or c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or c:IsLevelBelow(2) then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.lvfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	local lvs={}
	if c:IsLevelAbove(3) and aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(2),0) then table.insert(lvs,2) end
	if c:IsLevelAbove(5) and aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(4),0) then table.insert(lvs,4) end
	if #lvs<1 then return end
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvs))
	if c:UpdateLevel(-lv)~=-lv then return end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.lvrescon(lv),1,tp,HINTMSG_SPSUMMON,s.lvrescon(lv))
	if #tg>0 and Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_DEFENSE)>0 then
		local fdg=Duel.GetOperatedGroup():Match(Card.IsFacedown,nil)
		if #fdg==0 then return end
		Duel.ConfirmCards(1-tp,fdg)
	end
end