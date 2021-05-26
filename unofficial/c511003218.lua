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
	--Declare monster names then Tribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e1:SetCountLimit(1)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.typetg)
	c:RegisterEffect(e1)
	--Damage
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
function s.typetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ac1=Duel.AnnounceCard(tp,TYPE_MONSTER)
    	local ac2=Duel.AnnounceCard(tp,TYPE_MONSTER,OPCODE_ISTYPE,ac1,OPCODE_ISCODE,OPCODE_AND,OPCODE_NOT)
    	e:SetLabel(ac1)
    	e:GetLabelObject():SetLabel(ac2)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.relfilter(c,code1,code2)
	return c:IsReleasable() and c:IsCode(code) and c:IsFaceup()
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_MZONE,0,nil,e:GetLabel(),e:GetLabelObject():GetLabel())
    	return e:GetHandler():GetFlagEffect(id)>0 and #g>0
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_MZONE,0,nil,e:GetLabel(),e:GetLabelObject():GetLabel())
    	local g2=Duel.GetMatchingGroup(s.relfilter,tp,0,LOCATION_MZONE,nil,e:GetLabel(),e:GetLabelObject():GetLabel())
	if #g1>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local sg=Duel.SelectMatchingCard(tp,s.relfilter,tp,LOCATION_MZONE,0,1,1,nil,e:GetLabel(),e:GetLabelObject():GetLabel())
		local tc=sg:GetFirst()
		local atk=(tc:GetAttack()/2)
		local typ=tc:GetCode()
		if Duel.Release(tc,REASON_EFFECT)>0 then
			if Duel.IsExistingMatchingCard(s.relfilter,tp,0,LOCATION_MZONE,1,nil,typ) and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_RELEASE)
				local sg2=Duel.SelectMatchingCard(1-tp,s.relfilter,1-tp,LOCATION_MZONE,0,1,1,nil,typ)
				local tc2=sg2:GetFirst()
				Duel.Release(tc2,REASON_EFFECT)	   
			else	 
				Duel.Damage(1-tp,atk,REASON_EFFECT)
			end
		end
	end
end
