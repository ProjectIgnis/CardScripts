--神の進化
--Divine Evolution
--updated by Larry126
Duel.EnableUnofficialProc(PROC_DIVINE_HIERARCHY)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:HasFlagEffect(FLAG_DIVINE_HIERARCHY) and not c:HasFlagEffect(id+1000)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local hr=tc:GetFlagEffectLabel(FLAG_DIVINE_HIERARCHY)+1
		tc:ResetFlagEffect(FLAG_DIVINE_HIERARCHY)
		tc:RegisterFlagEffect(FLAG_DIVINE_HIERARCHY,RESET_EVENT|RESETS_STANDARD,0,1,hr)
		--Atk/Def up
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		if tc:IsOriginalCode(513000135) then
			--change name
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CHANGE_CODE)
			e3:SetValue(511600030)
			e3:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		tc:RegisterFlagEffect(id+1000,RESET_EVENT|RESETS_STANDARD,0,1)
	end
end