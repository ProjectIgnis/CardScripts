--太陽神の鉄檻－ラヴァ・ゴーレム
--The Sun God's Steelcage - Lava Golem
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 "Sun God" monster you control + 2 face-up monsters on the field
	Fusion.AddProcMixN(c,false,false,s.matfilter,1,aux.AND(Card.IsFaceup,Card.IsOnField),2)
	--Cannot be used as Fusion Material
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE)
	e0a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0a:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e0a:SetValue(1)
	c:RegisterEffect(e0a)
	--Must be either Fusion Summoned, or Special Summoned (from your Extra Deck) to your opponent's Main Monster Zone by sending the above cards from either field to the GY, but if you Special Summon this card with the second method, you can only Special Summon once for the rest of this turn
	c:AddMustBeFusionSummoned()
	local e0b=Fusion.CreateContactProc(c,s.contactfil,s.contactop,nil,nil,1,aux.Stringid(id,0),false)
	e0b:SetProperty(EFFECT_FLAG_SPSUM_PARAM+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0b:SetTargetRange(POS_FACEUP,1)
	e0b:SetValue(function(e,c)
		return 1,ZONES_MMZ
	end)
	c:RegisterEffect(e0b)
	--You can only Special Summon "The Sun God's Steelcage - Lava Golem" once per turn this way, no matter which method you use
	local e0c=Effect.CreateEffect(c)
	e0c:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0c:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0c:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0c:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		return c:IsFusionSummoned() or c:IsSummonType(SUMMON_TYPE_SPECIAL+1)
	end)
	e0c:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local summon_player=c:GetSummonPlayer()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c,sump,sumtype)
			return c:IsOriginalCode(id) and (sumtype&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION or sumtype&SUMMON_TYPE_SPECIAL+1==SUMMON_TYPE_SPECIAL+1)
		end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,summon_player)
	end)
	c:RegisterEffect(e0c)
	--Once per turn, during your Standby Phase: Take 1000 damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsTurnPlayer(tp)
	end)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
s.listed_series={SET_SUN_GOD}
s.material_setcode={SET_SUN_GOD}
function s.matfilter(c,fc,sumtype,tp)
	return c:IsSetCard(SET_SUN_GOD,fc,sumtype,tp) and c:IsControler(tp) and c:IsOnField()
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
end
function s.contactop(g,tp,c)
	Duel.SendtoGrave(g,REASON_COST|REASON_MATERIAL)
	local prev_sp_activity_count=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
	--But if you Special Summon this card with the second method, you can only Special Summon once for the rest of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,tp)
		local current_sp_activity_count=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
		return current_sp_activity_count>prev_sp_activity_count+1
	end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end