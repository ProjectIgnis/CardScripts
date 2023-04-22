--Delicious Morsel!
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabelObject(e)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_series={SET_VAMPIRE}
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--Effect handling for battle damage from your Zombie "Vampire" monsters
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		ge1:SetCode(EVENT_BATTLE_DAMAGE)
		ge1:SetCondition(s.damcon)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
	--Battle Damage Register
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(0x5f)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(s.damcon)
	e1:SetOperation(s.damop)
	Duel.RegisterEffect(e1,tp)
	--Recover
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(0x5f)
	e2:SetCountLimit(1)
	e2:SetCondition(s.reccon)
	e2:SetOperation(s.recop)
	Duel.RegisterEffect(e2,tp)
end
function s.vfilter(c,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsSetCard(SET_VAMPIRE) and c:IsControler(tp)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.vfilter,1,nil,tp) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local dam=0
	if Duel.GetFlagEffectLabel(tp,id+100)~=nil then dam=Duel.GetFlagEffectLabel(tp,id+100) end
	Duel.ResetFlagEffect(tp,id+100)
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1,dam+ev)
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0 and Duel.GetFlagEffect(tp,id+100)>0
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local heal=0
	if Duel.GetFlagEffectLabel(tp,id+100)~=nil then heal=(Duel.GetFlagEffectLabel(tp,id+100)/2) end
	Duel.Recover(tp,heal,REASON_EFFECT)
end