--デストーイ・チェーン・シープ (Anime)
--Frightfur Sheep (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: "Fluffal Sheep" + "Edge Imp Chain"
	Fusion.AddProcMix(c,true,true,98280324,61173621)
	--Your opponent cannot activate Spell/Trap cards until the end of the Battle Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetHintTiming(TIMING_BATTLE_PHASE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(function(e) return Duel.GetAttacker()==e:GetHandler() and not e:GetHandler():HasFlagEffect(id) end)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
end
s.material_setcode={SET_FLUFFAL,SET_EDGE_IMP}
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE,0,1)
	--Prevent Spell/Trap Card activations until the end of the Battle Phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(function(e,re,tp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) end)
	e1:SetReset(RESET_PHASE|PHASE_BATTLE)
	Duel.RegisterEffect(e1,tp)
end	
