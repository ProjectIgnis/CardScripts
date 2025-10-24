--Pulling the Strings
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--Give control of a monster to your opponent
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetTarget(function(e,tp) return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,LOCATION_MZONE,0,1,nil) end)
	e1:SetOperation(s.ctrlop)
	Duel.RegisterEffect(e1,tp)
	--Destroy 1 monster your opponent controls that you own/inflict damage
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(0x5f)
	e2:SetCountLimit(1)
	e2:SetTarget(function(e,tp) return Duel.IsTurnPlayer(1-tp) and Duel.IsExistingMatchingCard(Card.IsOwner,tp,0,LOCATION_MZONE,1,nil,tp) and not Duel.HasFlagEffect(tp,id) end)
	e2:SetOperation(s.desop)
	Duel.RegisterEffect(e2,tp)
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Change control of a monster in your control
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectMatchingCard(tp,Card.IsControlerCanBeChanged,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	Duel.HintSelection(tc,true)
	if tc and Duel.GetControl(tc,1-tp) then
		--That monster cannot be Tributed
		local e1a=Effect.CreateEffect(e:GetHandler())
		e1a:SetDescription(3303)
		e1a:SetType(EFFECT_TYPE_SINGLE)
		e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1a:SetRange(LOCATION_MZONE)
		e1a:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1a:SetValue(1)
		e1a:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1a)
		local e1b=e1a:Clone()
		e1b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e1b)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		--You can only use this Skill once per Duel
		Duel.RegisterFlagEffect(tp,id,0,0,0)
		--Destroy 1 monster your opponent controls that you own and inflict 500 damage
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=Duel.SelectMatchingCard(tp,Card.IsOwner,tp,0,LOCATION_MZONE,1,1,nil,tp)
		Duel.HintSelection(sg,true)
		if #sg>0 and Duel.Destroy(sg,REASON_EFFECT)>0 then
			Duel.Damage(1-tp,500,REASON_EFFECT)
		end
		local c=e:GetHandler()
		--You take no damage from cards you own for the rest of this Duel
		local e1a=Effect.CreateEffect(e:GetHandler())
		e1a:SetDescription(aux.Stringid(id,2))
		e1a:SetType(EFFECT_TYPE_FIELD)
		e1a:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1a:SetCode(EFFECT_CHANGE_DAMAGE)
		e1a:SetRange(0x5f)
		e1a:SetTargetRange(1,0)
		e1a:SetValue(s.damval)
		Duel.RegisterEffect(e1a,tp)
		local e1b=e1a:Clone()
		e1b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		Duel.RegisterEffect(e1b,tp)
	end
end
function s.val(e,re,val,r,rp,rc)
	if rc:IsOwner(e:GetHandlerPlayer()) then 
		return 0
	else 
		return val 
	end
end
