--サイコ・ギガサイバー
--Psychic Megacyber
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Move monster to the Spell/Trap zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_JINZO}
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		Duel.GetMatchingGroupCount(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)>Duel.GetMatchingGroupCount(Card.IsSpellTrap,tp,LOCATION_ONFIELD,0,nil)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_JINZO),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=Duel.GetAttackTarget()
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_SZONE,tp)>0
		and d and d:IsControler(1-tp) and d:IsFaceup() and d:IsType(TYPE_EFFECT) end
	d:CreateEffectRelation(e)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() and d:IsControler(1-tp) and d:IsRelateToEffect(e) and not d:IsImmuneToEffect(e) then
		if Duel.GetLocationCount(1-tp,LOCATION_SZONE)==0 then
			Duel.SendtoGrave(d,REASON_RULE,nil,PLAYER_NONE)
		elseif Duel.MoveToField(d,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true) then
			--Treated as a Continuous Trap
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
			e1:SetValue(TYPE_TRAP|TYPE_CONTINUOUS)
			d:RegisterEffect(e1)
		end
	end
end