--冥骸融合－メメント・フュージョン
--Mementotlan Fusion
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 Fusion Monster, including 1 "Memento" monster as material
	local e1=Fusion.CreateSummonEff({handler=c,extrafil=s.fextra,extratg=s.extratg,extraop=s.extraop})
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--Destroy 1 "Memento" monster you control and search 1 "Memento" Spell/Trap
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Register destruction of monsters
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROY)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={SET_MEMENTO}
function s.checkfilter(c)
	return (c:IsPreviousLocation(LOCATION_MZONE) or (c:IsMonster() and not c:IsPreviousLocation(LOCATION_ONFIELD))) and c:IsReason(REASON_EFFECT)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.checkfilter,nil)
	if #g==0 then return end
	for p=0,1 do
		if g:IsExists(Card.IsPreviousControler,1,nil,p) and not Duel.HasFlagEffect(p,id) then
			Duel.RegisterFlagEffect(p,id,RESET_PHASE|PHASE_END,0,1)
		end
	end
end
function s.extramatfilter(c)
	return c:IsSetCard(SET_MEMENTO) and c:IsAbleToDeck()
end
function s.checkmat(tp,sg,fc)
	return sg:IsExists(Card.IsSetCard,1,nil,SET_MEMENTO)
end
function s.fextra(e,tp,mg)
	local sg=nil
	if Duel.HasFlagEffect(tp,id) then
		sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.extramatfilter),tp,LOCATION_GRAVE,0,nil)
	end
	return sg,s.checkmat
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.HintSelection(rg,true)
		Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
		sg:RemoveCard(rg)
	end
end
function s.thfilter(c)
	return c:IsSetCard(SET_MEMENTO) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local desg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,0,1,1,nil)
	if Duel.Destroy(desg,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local hg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #hg>0 then
		Duel.SendtoHand(hg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,hg)
	end
end