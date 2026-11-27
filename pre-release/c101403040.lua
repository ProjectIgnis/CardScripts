--ダラダラサウルス
--Lethargisaurus
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Defense Position Tuner + 1+ Defense Position non-Tuners
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsDefensePos),1,1,Synchro.NonTunerEx(Card.IsDefensePos),1,99)
	--If this card is Special Summoned in Attack Position: Change it to Defense Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsAttackPos()
	end)
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,tp,POS_FACEUP_DEFENSE)
	end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		end
	end)
	c:RegisterEffect(e1)
	--This Defense Position card gains these effects
	--● Change all face-up monsters on the field to Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_POSITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(s.defposcon)
	e2:SetTarget(function(e,c)
		return c:IsFaceup()
	end)
	e2:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e2)
	--● Neither player can activate cards or effects in response to the activation of their own cards or effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.defposcon)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		Duel.SetChainLimit(function(e,tp,_rp)
			return _rp==1-rp
		end)
	end)
	c:RegisterEffect(e3)
	--● Once per turn, during the End Phase: Each player gains 500 LP for each Defense Position monster they control
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.defposcon)
	e4:SetTarget(s.lpgaintg)
	e4:SetOperation(s.lpgainop)
	c:RegisterEffect(e4)
end
function s.defposcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsDefensePos()
end
function s.lpgaintg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local def_pos_count=Duel.GetMatchingGroupCount(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,PLAYER_ALL,500*def_pos_count)
end
function s.lpgainop(e,tp,eg,ep,ev,re,r,rp)
	local turn_player=Duel.GetTurnPlayer()
	local turn_player_count=Duel.GetMatchingGroupCount(Card.IsDefensePos,turn_player,LOCATION_MZONE,0,nil)
	local non_turn_player_count=Duel.GetMatchingGroupCount(Card.IsDefensePos,turn_player,0,LOCATION_MZONE,nil)
	Duel.Recover(turn_player,500*turn_player_count,REASON_EFFECT)
	Duel.Recover(1-turn_player,500*non_turn_player_count,REASON_EFFECT)
end