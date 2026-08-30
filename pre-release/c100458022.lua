--レイズ・ムーンの天 シエロ－ノーモアベット
--Raise Moon Sky Cielo - No More Bets
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 7 "Raise Moon" monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_RAISE_MOON),7,2)
	--Cannot be used as material for a Fusion, Xyz, or Link Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e0:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
	c:RegisterEffect(e0)
	--If this card in your possession is sent to your GY by an opponent's card: You can draw 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	--Gains these effects while in the Extra Monster Zone
	--● Unaffected by other cards' effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_EMZONE)
	e2:SetValue(function(e,te)
		return te:GetOwner()~=e:GetOwner()
	end)
	c:RegisterEffect(e2)
	--● When a card or effect activated by your opponent resolves that includes an effect that adds a card(s) from the Deck to the hand, you can make that effect become "Draw 1 card"
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_EMZONE)
	e3:SetCondition(s.changecon)
	e3:SetOperation(s.changeop)
	c:RegisterEffect(e3)
	--● Once per turn (Quick Effect): You can detach 1 material from this card; draw 1 card
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_EMZONE)
	e4:SetCountLimit(1)
	e4:SetCost(Cost.DetachFromSelf(1))
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	e4:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e4)
end
s.listed_seriess={SET_RAISE_MOON}
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousControler(tp) and rp==1-tp
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end
function s.check(ev,re)
	return function(category,checkloc)
		if not checkloc and re:IsHasCategory(category) then return true end
		local ex1,g1,gc1,dp1,dv1=Duel.GetOperationInfo(ev,category)
		local ex2,g2,gc2,dp2,dv2=Duel.GetPossibleOperationInfo(ev,category)
		if not (ex1 or ex2) then return false end
		if category==CATEGORY_DRAW then return true end
		local g=Group.CreateGroup()
		if g1 then g:Merge(g1) end
		if g2 then g:Merge(g2) end
		return (((dv1 or 0)|(dv2 or 0))&LOCATION_DECK)~=0 or (#g>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK))
	end
end
function s.changecon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	local checkfunc=s.check(ev,re)
	return checkfunc(CATEGORY_TOHAND,true) or checkfunc(CATEGORY_DRAW,true) or checkfunc(CATEGORY_DRAW,false)
		or checkfunc(CATEGORY_SEARCH,false)
end
function s.changeop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerCanDraw(1-tp,1) and Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,2)) then
		Duel.Hint(HINT_CARD,0,id)
		local g=Group.CreateGroup()
		Duel.ChangeTargetCard(ev,g)
		Duel.ChangeChainOperation(ev,s.drop)
	end
end