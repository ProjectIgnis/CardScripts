--マシン・インスペクター
--Machine Inspector
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Add excavated monster to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4
		and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=4 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,0,0)
end
function s.filter(c)
	return (c:IsMonster() and c:IsRace(RACE_MACHINE)) or c:IsTrap()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<4 then return end
	Duel.ConfirmDecktop(tp,4)
	Duel.ConfirmDecktop(1-tp,4)
	local g=Duel.GetDecktopGroup(tp,4)
	local g2=Duel.GetDecktopGroup(1-tp,4)
	Duel.DisableShuffleCheck()
	local sg=Group.CreateGroup()
	sg:AddCard(g)
	sg:AddCard(g2)
	local og=nil
	if sg:IsExists(s.filter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local dg=sg:FilterSelect(tp,s.filter,1,2,nil)
		for tc in dg:Iter() do
			if tc:GetOwner()==tp then
				g:RemoveCard(tc)
			else
				g2:RemoveCard(tc)
			end
		end
		Duel.SendtoGrave(dg,REASON_EFFECT)
		og=Duel.GetOperatedGroup()
		Duel.BreakEffect()
	end
	--Place on bottom of the Deck
	local ct1=#g
	if ct1>0 then
		Duel.MoveToDeckBottom(ct1,tp)
		Duel.SortDeckbottom(tp,tp,ct1)
	end
	local ct2=#g2
	if ct2>0 then
		Duel.MoveToDeckBottom(ct2,1-tp)
		Duel.SortDeckbottom(1-tp,1-tp,ct2)
	end
	--Draw 1 card
	if og and og:FilterCount(Card.IsTrap,nil)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
