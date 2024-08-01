--Japanese name
--Necroquip Princess
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 monster equipped with a Monster Card + 1 Fiend Monster Card
	Fusion.AddProcMix(c,true,true,s.eqmatfilter,s.fiendmatfilter)
	--Must be Special Summoned by sending the materials to the GY
	Fusion.AddContactProc(c,function(tp) return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD|LOCATION_HAND,0,nil) end,function(g) Duel.SendtoGrave(g,REASON_COST|REASON_MATERIAL) end,true)
	--You can only control 1 "Necroquip Princess"
	c:SetUniqueOnField(1,0,id)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.effcon)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
function s.eqmatfilter(c)
	return c:GetEquipGroup():IsExists(Card.IsMonsterCard,1,nil)
end
function s.fiendmatfilter(c,fc,sumtype,tp)
	return c:IsMonsterCard() and c:IsRace(RACE_FIEND,fc,sumtype,tp)
end
function s.effconfilter(c)
	return c:IsMonster() and c:IsReason(REASON_COST) and c:IsPreviousLocation(LOCATION_HAND)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.effconfilter,1,nil) and re:IsActivated()
end
function s.eqfilter(c,tp)
	return s.effconfilter(c) and c:CheckUniqueOnField(tp) and (c:IsControler(tp) or c:IsAbleToChangeControler())
		and not c:IsForbidden() and c:IsLocation(LOCATION_GRAVE)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and eg:IsExists(s.eqfilter,1,nil,tp)
	local b2=Duel.IsPlayerCanDraw(tp,1)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		Duel.SetTargetCard(eg)
		e:SetCategory(CATEGORY_EQUIP)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,eg,1,tp,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Equip 1 of those monsters to this card as an Equip Spell that gives it 500 ATK
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local ec=Duel.GetTargetCards(e):FilterSelect(tp,s.eqfilter,1,1,nil,tp):GetFirst()
		if ec and Duel.Equip(tp,ec,c) then
			--The equipped monster gains 500 ATK
			local e1=Effect.CreateEffect(ec)
			e1:SetType(EFFECT_TYPE_EQUIP)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			ec:RegisterEffect(e1)
			--Equip limit
			local e2=Effect.CreateEffect(ec)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_EQUIP_LIMIT)
			e2:SetValue(function(e,cc) return cc==c end)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			ec:RegisterEffect(e2)
		end
	elseif op==2 then
		--Draw 1 card
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end