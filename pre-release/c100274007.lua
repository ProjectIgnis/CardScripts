--古生代化石マシン スカルコンボイ
--Fossil Machine Skull Convoy
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Susion summon procedure
	Fusion.AddProcMix(c,true,true,s.ffilter,aux.FilterBoolFunctionEx(Card.IsLevelAbove,7))
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Clock Lizard check
	Auxiliary.addLizardCheck(c)
	--Must first be special summoned with "Fossil Fusion"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetValue(aux.FossilLimit)
	c:RegisterEffect(e0)
	--Opponent's monsters loses ATK equal to their original DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--Can make 3 attacks on monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetValue(2)
	c:RegisterEffect(e2)
	--Inflict 1000 damage after destroying a monster by battle
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
--Specifically lists "Fossil Fusion"
s.listed_names={CARD_FOSSIL_FUSION}

	--Check for a rock monster in your GY
function s.ffilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_ROCK) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)
end
	--If fusion summoned
function s.condition(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
	--Get original DEF
function s.atkval(e,c)
	local val=math.max(c:GetBaseDefense(),0)
	return val*-1
end
	--Activation legality
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
	--Inflict 1000 damage after destroying a monster by battle
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end