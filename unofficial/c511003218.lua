--エクトプラズマー (Anime)
--Ectoplasmer (Anime)
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Declare monster names
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.declaretg)
	c:RegisterEffect(e1)
	--Tribute and damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
function s.declaretg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ac1=Duel.AnnounceCard(tp,TYPE_MONSTER)
	local ac2=Duel.AnnounceCard(tp,TYPE_MONSTER,OPCODE_ISTYPE,ac1,OPCODE_ISCODE,OPCODE_NOT,OPCODE_AND)
	e:SetLabel(ac1)
	e:GetLabelObject():SetLabel(ac2)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.relfilter(c,code1,code2)
	return c:IsReleasable() and c:IsCode(code1,code2) and c:IsFaceup()
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0 and Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE,0,1,nil,e:GetLabel(),e:GetLabelObject():GetLabel())
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g1=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_MZONE,0,nil,e:GetLabel(),e:GetLabelObject():GetLabel())
	if #g1>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local tc=g1:Select(tp,1,1,nil):GetFirst()
		local atk=(tc:GetAttack()/2)
		local code=tc:GetCode()
		if Duel.Release(tc,REASON_EFFECT)>0 then
			local g2=Duel.GetMatchingGroup(s.relfilter,1-tp,LOCATION_MZONE,0,nil,code)
			if #g2>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
				Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_RELEASE)
				local tc2=g2:Select(tp,1,1,nil):GetFirst()
				Duel.Release(tc2,REASON_EFFECT) 
			else	 
				Duel.Damage(1-tp,atk,REASON_EFFECT)
			end
		end
	end
end