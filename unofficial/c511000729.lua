--バーサーク・モード
--Berserk Mode
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(function() return Duel.IsBattlePhase() end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)>0 end
	local sg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,#sg,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	if #sg>0 then
		Duel.ChangePosition(sg,POS_FACEUP_ATTACK)
		for tc in aux.Next(sg) do
			--Must attack, if able to
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3200)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_MUST_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
			tc:RegisterEffect(e1)
			--Cannot change their battle positions
			local e2=e1:Clone()
			e2:SetDescription(3313)
			e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			tc:RegisterEffect(e2)
			--Attack cannot be negated
			local e3=e1:Clone()
			e3:SetDescription(aux.Stringid(id,0))
			e3:SetCode(EFFECT_MUST_ATTACK)
			tc:RegisterEffect(e3)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
		end
	end
end
function s.befilter(c)
	return c:GetFlagEffect(id)~=0 and c:CanAttack()
end