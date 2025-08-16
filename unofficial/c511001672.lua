--オーバーレイ・ブレイク
--Overlay Break
Duel.LoadScript("c420.lua")
Duel.EnableUnofficialProc(PROC_CANNOT_BATTLE_INDES)
local s,id=GetID()
function s.initial_effect(c)
	--Send the materials of 1 Xyz Monster on the field to the GY, then negate any of its "Cannot be destroyed by battle" effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.detachfilter(c)
	return c:IsFaceup() and c:IsXyzMonster() and c:GetOverlayCount()>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.detachfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.detachfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
	Duel.SelectTarget(tp,s.detachfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local og=tc:GetOverlayGroup()
		Duel.SendtoGrave(og,REASON_EFFECT)
		if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_BATTLE_INDES)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(s.batval)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
function s.batval(e,re)
	return (re:GetCode()==EFFECT_INDESTRUCTABLE_BATTLE or re:GetCode()==EFFECT_INDESTRUCTABLE_COUNT)
		and (not re:IsHasType(EFFECT_TYPE_SINGLE) or re:GetOwner()==e:GetHandler())
		and (not re:IsHasType(EFFECT_TYPE_FIELD) or re:GetActivateLocation()>0)
		and not re:GetHandler():IsHasEffect(EFFECT_CANNOT_DISABLE)
		and not re:IsHasProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
end
