--Under Pressure
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
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
s.listed_names={22587018,58071123,15981690,62397231}
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
end
function s.hyofilter(c)
	return c:IsFaceup() and c:IsCode(62397231)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.hyofilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.ConfirmDecktop(tp,4)
	local c=e:GetHandler()
	local g=Duel.GetDecktopGroup(tp,4)
	--Carbonnedon effect check (Hyozanryu gains 1000 ATK)
	if g:IsExists(Card.IsCode,1,nil,15981690) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local tc=Duel.SelectMatchingCard(tp,s.hyofilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
	--Hydrogeddon effect check (Hyozanryu unaffected by opponent's monster effects)
	if g:IsExists(Card.IsCode,1,nil,22587018) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
		local sc=Duel.SelectMatchingCard(tp,s.hyofilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(s.efilter)
		sc:RegisterEffect(e2)
	end
	--Oxygeddon effect check (Destroy 1 face-up monster you opponent controls and inflict 800 damage)
	if g:IsExists(Card.IsCode,1,nil,58071123) then
		if not Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_MZONE,1,nil,TYPE_MONSTER) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,Card.IsType,tp,0,LOCATION_MZONE,1,1,nil,TYPE_MONSTER)
		Duel.HintSelection(dg)
		if Duel.Destroy(dg,REASON_EFFECT)>0 then
			Duel.Damage(1-tp,800,REASON_EFFECT)
		end
	end
	Duel.MoveToDeckBottom(g,tp)
	Duel.SortDeckbottom(tp,tp,4)
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end