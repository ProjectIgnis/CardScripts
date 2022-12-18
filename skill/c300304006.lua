--Crystal Transcendence
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
s.listed_series={SET_CRYSTAL,SET_CRYSTAL_BEAST}
function s.filter(c)
	return c:IsSetCard(SET_CRYSTAL_BEAST) and c:IsMonster()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(ep,id)<2
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--TPD Register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Send from hand to GY/Place Crystal Beasts in S/T Zones as Cont. Spells
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,math.min(g:GetClassCount(Card.GetCode),ft,3),nil)
	if Duel.SendtoGrave(dg,REASON_COST)>0 and dg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==#dg then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,math.min(3,#dg),aux.dncheck,1,tp,HINTMSG_TOFIELD)
		if #sg>0 then
			for sc in sg:Iter() do
				Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
				--Treat it as a Continuous Spell
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_TYPE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
				e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
				sc:RegisterEffect(e1)
				Duel.RaiseEvent(sc,EVENT_CUSTOM+47408488,e,0,tp,0,0)
			end
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_MSET)
	Duel.RegisterEffect(e4,tp)
end
function s.sumlimit(e,c)
	return not (c:IsRace(RACE_DRAGON) or c:IsSetCard(SET_CRYSTAL))
end