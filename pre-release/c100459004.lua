--神を超えたしもべ－青眼の究極竜
--Blue-Eyes Ultimate Dragon, the God-Surpassing Servant
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: "Blue-Eyes White Dragon" + "Blue-Eyes White Dragon" + "Blue-Eyes White Dragon"
	Fusion.AddProcMixN(c,true,true,CARD_BLUEEYES_W_DRAGON,3)
	--Cannot be destroyed by card effects, also unaffected by your opponent's activated effects during your opponent's turn
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetValue(1)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_IMMUNE_EFFECT)
	e1b:SetCondition(function(e)
		return Duel.IsTurnPlayer(1-e:GetHandlerPlayer())
	end)
	e1b:SetValue(function(e,te)
		return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated()
	end)
	c:RegisterEffect(e1b)
	--Can make up to 3 attacks during each Battle Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(2)
	c:RegisterEffect(e2)
	--Once per Chain, during the Battle Phase (Quick Effect): You can target 1 monster that was Special Summoned this turn, or 1 face-down card, that your opponent controls; destroy it. You can only use this effect of "Blue-Eyes Ultimate Dragon, the God-Surpassing Servant" thrice per turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(3,id)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsBattlePhase()
	end)
	e3:SetCost(Cost.SoftOncePerChain(id))
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	e3:SetHintTiming(TIMING_CHAIN_END|TIMING_BATTLE_END,TIMING_CHAIN_END|TIMING_BATTLE_START|TIMING_BATTLE_STEP_END|TIMING_BATTLE_END)
	c:RegisterEffect(e3)
end
s.material_setcode=SET_BLUE_EYES
s.listed_names={CARD_BLUEEYES_W_DRAGON}
function s.desfilter(c)
	return (c:IsMonster() and c:IsStatus(STATUS_SPSUMMON_TURN)) or c:IsFacedown()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and s.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end