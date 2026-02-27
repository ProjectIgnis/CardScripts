--地縛神 Ｃｕｓｉｌｌｕ (Anime)
--Earthbound Immortal Cusillu (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Neither player can Summon "Earthbound Immortal" monsters
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_FIELD)
	e0a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0a:SetCode(EFFECT_CANNOT_SUMMON)
	e0a:SetRange(LOCATION_MZONE)
	e0a:SetTargetRange(1,1)
	e0a:SetTarget(s.sumlimit)
	c:RegisterEffect(e0a)
	local e0b=e0a:Clone()
	e0b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e0b)
	local e0c=e0a:Clone()
	e0c:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e0c)
	--If there is no face-up Field Spell, destroy this card during the End Phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e) return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil) end)
	e1:SetOperation(function(e) Duel.Destroy(e:GetHandler(),REASON_EFFECT) end)
	c:RegisterEffect(e1)
	--This card can attack your opponent directly while there is a face-up card in the Field Zone
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(function(e) return Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil) end)
	c:RegisterEffect(e2)
	--Cannot be targeted for attacks
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e) return Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil) end)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--Unaffected by your opponent's Spell and Trap effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetCondition(function(e) return Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil) end)
	e4:SetValue(function(e,te) return te:IsSpellTrapEffect() and te:GetOwnerPlayer()~=e:GetHandlerPlayer() end)
	c:RegisterEffect(e4)
	--If this card would be destroyed by battle, you can Tribute 1 other monster you control instead, and if do you, halve your opponent's Life Points
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetCondition(function(e) return Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil) end)
	e5:SetTarget(s.replacetg)
	c:RegisterEffect(e5)
end
s.listed_series={SET_EARTHBOUND_IMMORTAL}
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsSetCard(SET_EARTHBOUND_IMMORTAL)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE) and c:GetBattlePosition()~=POS_FACEUP_DEFENSE
		and Duel.CheckReleaseGroup(tp,Card.IsReleasableByEffect,1,c) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		local g=Duel.SelectReleaseGroup(tp,Card.IsReleasableByEffect,1,1,c)
		Duel.Release(g,REASON_EFFECT)
		Duel.SetLP(1-tp,Duel.GetLP(1-tp)/2)
		return true
	else
		return false
	end
end
