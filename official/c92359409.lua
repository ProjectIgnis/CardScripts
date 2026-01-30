--超弩級砲塔列車グスタフ・ロケット
--Superdreadnought Rail Cannon Gustav Rocket
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 10 monsters, OR by discarding 1 card and using "Superdreadnought Rail Cannon Gustav Max" you control
	Xyz.AddProcedure(c,nil,10,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)
	--Negate that effect, and if you do, destroy that monster, then inflict 1000 damage to your opponent
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--Detach 1 material from this card or destroy it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e2:SetTarget(s.detachtg)
	e2:SetOperation(s.detachop)
	c:RegisterEffect(e2)
end
s.listed_names={id,56910167} --"Superdreadnought Rail Cannon Gustav Max"
function s.ovfilter(c,tp,xyzc)
	return c:IsSummonCode(xyzc,SUMMON_TYPE_XYZ,tp,56910167) and c:IsFaceup()
end
function s.xyzop(e,tp,chk,mc)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local sc=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,nil):SelectUnselect(Group.CreateGroup(),tp,false,Xyz.ProcCancellable)
	if sc and Duel.SendtoGrave(sc,REASON_DISCARD|REASON_COST)>0 then
		return Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
	else
		return false
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and e:GetHandler():GetOverlayCount()>0 and Duel.IsChainDisablable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
function s.detachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	if c:GetOverlayCount()==0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,tp,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,c,1,tp,0)
end
function s.detachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local b1=c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
	local b2=true
	--Detach 1 material from this card or destroy it
	local op=b1 and Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,3)},
		{b2,aux.Stringid(id,4)}) or 2
	if op==1 then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	elseif op==2 then
		Duel.Destroy(c,REASON_EFFECT)
	end
end