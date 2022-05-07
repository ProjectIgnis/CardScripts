--
--Libromancer Bonded
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	Ritual.AddProcGreater({handler=c,filter=s.ritualfil,stage2=s.stage2})
end
s.listed_series={0x17d}
s.fit_monster={101108087,45001322}
function s.ritualfil(c)
	return c:IsSetCard(0x17d) and c:IsRitualMonster()
end
function s.mfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousCodeOnField()==45001322
end
function s.stage2(mg,e,tp,eg,ep,ev,re,r,rp,tc)
	if tc:IsCode(101108087) and mg:IsExists(s.mfilter,1,nil) then
		local c=e:GetHandler()
		--Cannot be destroyed by effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		--Cannot be banished by effects
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_REMOVE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTargetRange(1,1)
		e2:SetTarget(s.rmlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
end
function s.rmlimit(e,c,tp,r)
	return c==e:GetHandler() and r==REASON_EFFECT
end