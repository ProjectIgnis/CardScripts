--Ｓｉｎ Ｔｅｒｒｉｔｏｒｙ
--Malefic Territory
--Scripted by Eerie Code, credits to Cybercatman and edo9300 for the new Malefic filter
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--malefic change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(id)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e2)
	--adjust
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.adjustop)
	e3:SetCondition(s.validitycheck)
	c:RegisterEffect(e3)
	--cannot summon,spsummon,flipsummon
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(1,1)
	e4:SetTarget(s.sumlimit)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e6)
	--disable
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_DISABLE)
	e7:SetRange(LOCATION_SZONE)
	e7:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e7:SetCondition(s.discon)
	e7:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x23))
	c:RegisterEffect(e7)
end
s.listed_series={0x23}
s.listed_names={27564031}
function s.filter(c,tp)
	return c:IsCode(27564031) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if aux.PlayFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetRange(LOCATION_FZONE)
			e1:SetTargetRange(LOCATION_FZONE,LOCATION_FZONE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
		end
	end
end
function s.discon(e)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function s.stuff(c)
	local mt=c:GetMetatable()
	return c:IsFaceup() and mt.has_malefic_unique and mt.has_malefic_unique[c]==true and not c:IsDisabled() and c:IsSetCard(0x23)
end
function s.validitycheck()
	return Duel.IsExistingMatchingCard(s.stuff,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.rmfilter(c,...)
	return c:IsFaceup() and c:IsSetCard(0x23) and c:IsCode(...)
end
function s.rmfilter2(c,fieldid,...)
	return c:GetFieldID()<fieldid and c:IsCode(...)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	if sumpos and (sumpos&POS_FACEDOWN)>0 or (not s.stuff(c) or not s.validitycheck()) then return false end
	local tp=sump
	if targetp then tp=targetp end
	return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetCode())
end
function s.checkok(c,group)
	return group:IsExists(s.rmfilter2,1,c,c:GetFieldID(),c:GetCode())
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if (phase==PHASE_DAMAGE and not Duel.IsDamageCalculated()) or phase==PHASE_DAMAGE_CAL then return end
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsSetCard),0,LOCATION_MZONE,LOCATION_MZONE,nil,0x23)
	local sg=g:Filter(s.checkok,nil,g)
	if #sg>0 then
		Duel.Destroy(sg,REASON_RULE)
		Duel.Readjust()
	end
end
