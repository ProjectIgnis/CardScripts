--Energizing Elements
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and not Duel.HasFlagEffect(tp,id)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--OPD register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Energize!
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsMonster),tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_FIRE|ATTRIBUTE_WATER|ATTRIBUTE_EARTH|ATTRIBUTE_WIND)
	for tc in g:Iter() do
		--Monsters of declared Attribute gain 500 ATK/lose 400 DEF
		if tc:GetAttribute()&att>0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetValue(500)
			e1:SetReset(RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			e2:SetValue(-400)
			tc:RegisterEffect(e2)
			--Battle damage is halved
			local e3=e1:Clone()
			e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
			e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
			tc:RegisterEffect(e3)
		end
	end
	--Flip this Skill over if you control no monsters of the declared Attribute
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(0x5f)
	e1:SetLabel(att)
	e1:SetCondition(s.con)
	e1:SetOperation(s.op)
	Duel.RegisterEffect(e1,tp)
end
function s.con(e)
	local tp=e:GetHandlerPlayer()
	local att=e:GetLabel()
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsMonster),tp,LOCATION_MZONE,0,nil):Filter(Card.IsAttribute,nil,att)
	return #g==0
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local att=e:GetLabel()
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsMonster),tp,LOCATION_MZONE,0,nil):Filter(Card.IsAttribute,nil,att)
	if #g==0 then
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
		Duel.ResetFlagEffect(tp,id)
	end
end
