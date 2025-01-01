--土地ころがし
--Land Flipping
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Banish 1 Field Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
end
function s.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove() and not c:IsForbidden()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_FZONE) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,1-g:GetFirst():GetControler(),LOCATION_GRAVE)
end
function s.plfilter(c,targ_p,code)
	return c:IsFieldSpell() and not c:IsForbidden()
		and not c:IsOriginalCode(code) and (c:IsControler(targ_p) or c:IsAbleToChangeControler())
end
function s.placefield(c,tp,targ_p)
	local fc=Duel.GetFieldCard(targ_p,LOCATION_FZONE,0)
	if fc then
		Duel.SendtoGrave(fc,REASON_RULE)
		Duel.BreakEffect()
	end
	return Duel.MoveToField(c,tp,targ_p,LOCATION_FZONE,POS_FACEUP,true)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local old_fp=tc:GetControler()
	if not tc:IsRelateToEffect(e)
		or Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)==0
		or not tc:IsLocation(LOCATION_REMOVED)
		or (tc:IsControler(old_fp) and not tc:IsAbleToChangeControler())
		or tc:IsForbidden() then return end
	Duel.BreakEffect()
	if not s.placefield(tc,tp,1-old_fp) then return end
	local g=Duel.GetMatchingGroup(s.plfilter,tc:GetControler(),LOCATION_GRAVE,0,nil,old_fp,tc:GetOriginalCode())
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local pc=g:Select(tp,1,1,nil):GetFirst()
		if not pc then return end
		Duel.HintSelection(pc,true)
		Duel.BreakEffect()
		s.placefield(pc,tp,old_fp)
	end
end