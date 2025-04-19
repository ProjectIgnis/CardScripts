--機皇神龍アステリスク (Anime)
--Meklord Astro Dragon Asterisk (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Change ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--Inflict 1000 damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	--Cannot be targeted for attacks
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetValue(s.tg)
	c:RegisterEffect(e4)
	--Destroy replace
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetTarget(s.desreptg)
	c:RegisterEffect(e5)
end
s.listed_series={SET_MEKLORD}
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_MEKLORD),c:GetControler(),LOCATION_MZONE,0,3,nil)
end
function s.atkfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsRace(RACE_MACHINE)
end
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(s.atkfilter,c:GetControler(),LOCATION_MZONE,0,c)
	return g:GetSum(Card.GetAttack)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local t1=false
	local t2=false
	local tc=eg:GetFirst()
	while tc do
		if tc:IsType(TYPE_SYNCHRO) then
			if tc:IsSummonPlayer(tp) then t1=true else t2=true end
		end
		tc=eg:GetNext()
	end
	if t1 and not t2 then Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
	elseif not t1 and t2 then Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	else Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,1000) end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ex,g,gc,dp,dv=Duel.GetOperationInfo(0,CATEGORY_DAMAGE)
	if dp~=PLAYER_ALL then Duel.Damage(dp,1000,REASON_EFFECT)
	else
		Duel.Damage(tp,1000,REASON_EFFECT)
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
function s.tg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c~=e:GetHandler()
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_MACHINE),tp,LOCATION_MZONE,0,1,c) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsRace,RACE_MACHINE),tp,LOCATION_MZONE,0,1,1,c)
		Duel.SendtoGrave(g,REASON_EFFECT|REASON_REPLACE)
		return true
	else return false end
end