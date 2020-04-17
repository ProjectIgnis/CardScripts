--
--Taotie Dragon
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,2)
	--material verification
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.valcheck)
	c:RegisterEffect(e1)
	--effect registratrion
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
end
function s.matfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if not g then return end
	local typ=0
	for tc in aux.Next(g) do
		typ=(typ|tc:GetType())
	end
	typ=(typ&TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	e:SetLabel(typ)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabelObject():GetLabel()~=0
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local typ=e:GetLabelObject():GetLabel()
	local c=e:GetHandler()
	if (typ&TYPE_FUSION)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(0,1)
		e1:SetCondition(s.fuscond)
		e1:SetValue(s.fuslimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
	end
	if (typ&TYPE_SYNCHRO)~=0 then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTargetRange(0,1)
		e2:SetCondition(s.syncond)
		e2:SetValue(s.synlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
	if (typ&TYPE_XYZ)~=0 then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_ACTIVATE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetTargetRange(0,1)
		e3:SetCondition(s.xyzcond)
		e3:SetValue(s.xyzlimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
	end
end
function s.fuscond(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function s.fuslimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
function s.syncond(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()==tp and (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
function s.synlimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
function s.xyzcond(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()==tp and ((ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or  ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
function s.xyzlimit(e,re,tp)
	return re:GetHandler() and re:GetHandler():IsLocation(LOCATION_GRAVE)
end