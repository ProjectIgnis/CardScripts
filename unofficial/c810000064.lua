--シンクロニック・アビリティ
--Synchronic Ability
--Scripted by UnknownGuest
--Re-scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddEquipProcedure(c,nil,nil,nil,nil,nil,s.gainop)
end
function s.gainop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ADJUST)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOperation(s.op)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.codefilterchk(c,sc)
	return sc:GetFlagEffect(c:GetOriginalCode()+id)>0
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=e:GetOwner()
	if not c:GetEquipGroup():IsContains(ec) then
		e:Reset()
		return
	end
	local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c:GetRace())
	g:Remove(s.codefilterchk,nil,e:GetHandler())
	if c:IsFacedown() or #g<=0 or ec:IsDisabled() then return end
	for tc in aux.Next(g) do
		local code=tc:GetOriginalCode()
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD,1)
		c:RegisterFlagEffect(code+id,RESET_EVENT+RESETS_STANDARD,0,0)
		local e0=Effect.CreateEffect(c)
		e0:SetCode(id)
		e0:SetLabel(code)
		e0:SetLabelObject(ec)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e0,true)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ADJUST)
		e1:SetRange(LOCATION_MZONE)
		e1:SetLabel(cid)
		e1:SetLabelObject(e0)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetOperation(s.resetop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c:GetRace())
	if not g:IsExists(Card.IsOriginalCode,1,nil,e:GetLabelObject():GetLabel()) or not c:GetEquipGroup():IsContains(e:GetLabelObject():GetLabelObject()) or e:GetLabelObject():GetLabelObject():IsDisabled() then
		c:ResetEffect(e:GetLabel(),RESET_COPY)
		c:ResetFlagEffect(e:GetLabelObject():GetLabel()+id)
		e:GetLabelObject():Reset()
		e:Reset()
	end
end
