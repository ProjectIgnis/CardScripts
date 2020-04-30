--海晶乙女の決意
--Marincess Decision
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Link Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCost(s.linkcost)
	e1:SetTarget(s.linktg)
	e1:SetOperation(s.linkop)
	c:RegisterEffect(e1)
	--ATK down
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={0x12b}
function s.deffilter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE)
end
function s.lkfilter(c,mc)
	return c:IsLinkSummonable(mc)
end
function s.costfilter(c)
	return c:IsSetCard(0x12b) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.linkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.linktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsPosition(POS_FACEDOWN_DEFENSE) and chkc:IsControler(tp) and s.deffilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.deffilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWNDEFENSE)
	local g=Duel.SelectTarget(tp,s.deffilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.linkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.ChangePosition(tc,nil,nil,nil,POS_FACEUP_DEFENSE,true)
		Duel.BreakEffect()
		local tg=Duel.GetMatchingGroup(s.lkfilter,tp,LOCATION_EXTRA,0,nil,tc)
		if #tg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=tg:Select(tp,1,1,nil)
			local sc=sg:GetFirst()
			Duel.LinkSummon(tp,sc,tc)
		end
	end
end
function s.cfilter(c)
	return c:IsSetCard(0x12b) and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,c)
	e:SetLabel(g:GetFirst():GetBaseAttack())
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)   
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetTargetParam(e:GetLabel())
	e:SetLabel(0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local atk=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end