--天下独歩の大義賊
--The World's Greatest Gallant Thief
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If you control no monsters, you can Tribute Summon this card face-up by Tributing monsters from your hand and/or your opponent's field
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SUMMON_PROC)
	e0:SetCondition(function(e,c,minc,zone,relzone,exeff)
		if c==nil then return true end
		local min_tributes=c:GetTributeRequirement()
		if min_tributes<=0 then return false end
		local tp=c:GetControler()
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 then return false end
		local mg=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_HAND,LOCATION_MZONE,c,tp)
		return #mg>0 and #mg>=min_tributes
	end)
	e0:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
		local min_tributes,max_tributes=c:GetTributeRequirement()
		local mg=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_HAND,LOCATION_MZONE,c,tp)
		local sg=aux.SelectUnselectGroup(mg,e,tp,min_tributes,max_tributes,nil,1,tp,HINTMSG_RELEASE,nil,nil,true)
		if sg and #sg>0 then
			e:SetLabelObject(sg)
			return true
		end
		return false
	end)
	e0:SetOperation(function(e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
		local sg=e:GetLabelObject()
		if sg and #sg>0 then
			c:SetMaterial(sg)
			Duel.Release(sg,REASON_SUMMON|REASON_MATERIAL)
		end
	end)
	e0:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e0)
	--When your opponent activates a card effect in the hand, GY, or banishment, while you control this Normal Summoned/Set card (Quick Effect): You can negate that effect, and if you do, destroy that card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp,chk)
		return ep==1-tp and e:GetHandler():IsNormalSummoned() and Chain.IsTriggeringLocation(ev,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED)
			and Duel.IsChainDisablable(ev)
	end)
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
		local rc=re:GetHandler()
		if rc:IsDestructable() and rc:IsRelateToEffect(re) then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
		end
	end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end)
	c:RegisterEffect(e1)
	--During the Battle Phase (Quick Effect): You can reveal your entire hand; change all monsters your opponent controls to Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function()
		return Duel.IsBattlePhase()
	end)
	e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		if chk==0 then return #g>0 and not g:IsExists(Card.IsPublic,1,nil) end
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsAttackPos,Card.IsCanChangePosition),tp,0,LOCATION_MZONE,1,nil) end
		Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,POS_FACEUP_DEFENSE)
	end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local g=Duel.GetMatchingGroup(aux.AND(Card.IsAttackPos,Card.IsCanChangePosition),tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
		end
	end)
	e2:SetHintTiming(0,TIMING_BATTLE_START|TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
end