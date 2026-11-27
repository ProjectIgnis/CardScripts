--高嶺の天仙カリン
--Karin the Celestial Sage of the Highest Heights
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 7 monsters
	Xyz.AddProcedure(c,nil,7,2)
	--When your opponent activates a card or effect that includes an effect that Special Summons a monster(s) from the Deck (Quick Effect): You can detach 1 material from this card; your opponent draws 1 card, then negate that activated effect, and if you do, destroy that card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.discon)
	e1:SetCost(Cost.DetachFromSelf(1))
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--During your Main Phase 2: You can target 1 Level 7 monster in your GY; take damage equal to its ATK, and if you do, return both it and this card on the field to the hand/Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOHAND+CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsMainPhase2()
	end)
	e2:SetTarget(s.rthextg)
	e2:SetOperation(s.rthexop)
	c:RegisterEffect(e2)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	local ex1,g1,gc1,dp1,loc1=Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
	local ex2,g2,gc2,dp2,loc2=Duel.GetPossibleOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
	if not (ex1 or ex2) then return false end
	local g=Group.CreateGroup()
	if g1 then g:Merge(g1) end
	if g2 then g:Merge(g2) end
	return (((loc1 or 0)|(loc2 or 0))&LOCATION_DECK)>0 or (#g>0 and g:IsExists(function(c) return c:IsLocation(LOCATION_DECK) and c:IsMonster() end,1,nil))
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1) end
	local rc=re:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(1-tp,1,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
function s.rthexfilter(c)
	return c:IsLevel(7) and (c:IsAbleToHand() or c:IsAbleToExtra()) and c:HasNonZeroAttack()
end
function s.rthextg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	local c=e:GetHandler()
	if chk==0 then return (c:IsAbleToHand() or c:IsAbleToExtra())
		and Duel.IsExistingTarget(s.rthexfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local tc=Duel.SelectTarget(tp,s.rthexfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	local tg=Group.FromCards(c,tc)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,tc:GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,tg,2,tp,0)
end
function s.rthexop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Damage(tp,tc:GetAttack(),REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		Duel.SendtoHand(Group.FromCards(c,tc),nil,REASON_EFFECT)
	end
end