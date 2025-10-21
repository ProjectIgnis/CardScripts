--Ｎｏ．９５ ギャラクシーアイズ・ダークマター・ドラゴン (Anime)
--Number 95: Galaxy Eyes Dark Matter Dragon (Anime)
Duel.LoadCardScript("c58820923.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 9 monsters
	Xyz.AddProcedure(c,nil,9,3)
	--Cannot be destroyed by battle, except with "Number" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
	c:RegisterEffect(e1)
	--When this card is Xyz Summoned, it gains ATK equal to the ATK of the materials used for its Xyz Summon
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_SINGLE)
	e2a:SetCode(EFFECT_MATERIAL_CHECK)
	e2a:SetValue(function(e,c) e:SetLabel(c:GetMaterial():GetSum(Card.GetTextAttack)) end)
	c:RegisterEffect(e2a)
	local e2b=Effect.CreateEffect(c)
	e2b:SetDescription(aux.Stringid(id,0))
	e2b:SetCategory(CATEGORY_ATKCHANGE)
	e2b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2b:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e2b:SetOperation(function(e) e:GetHandler():UpdateAttack(e2a:GetLabel(),RESET_EVENT|RESETS_STANDARD_DISABLE,nil) end)
	c:RegisterEffect(e2b)
	--You banish Dragon monsters from your Deck, then your opponent banishes an equal number of monsters from their Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(s.sprmvtg)
	e3:SetOperation(s.sprmvop)
	c:RegisterEffect(e3)
	--This card can attack again in a row if it battles
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(function(e) local c=e:GetHandler() return Duel.GetAttacker()==c and c:CanChainAttack() end)
	e4:SetCost(Cost.DetachFromSelf(1))
	e4:SetOperation(function() Duel.ChainAttack() end)
	c:RegisterEffect(e4)
	--When this card battles an opponent's monster: You can banish that monster and this card
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_START)
	e5:SetTarget(s.batrmvtg)
	e5:SetOperation(s.batrmv)
	c:RegisterEffect(e5)
end
s.listed_series={SET_NUMBER}
s.xyz_number=95
function s.sprmvfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToRemove()
end
function s.sprmvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sprmvfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
function s.sprmvop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.sprmvfilter,tp,LOCATION_DECK,0,1,ct,nil)
	if #g>0 then
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT) then
			local sg=Duel.GetMatchingGroup(aux.AND(Card.IsMonster,Card.IsAbleToRemove),tp,0,LOCATION_DECK,nil)
			if #sg>=#g then
				Duel.ConfirmCards(tp,sg)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local ban=sg:Select(tp,1,#g,nil)
				Duel.Remove(ban,POS_FACEUP,REASON_EFFECT)
			else
				local dg=Duel.GetFieldGroup(tp,0,LOCATION_DECK)
				Duel.ConfirmCards(tp,dg)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local ban=sg:Select(tp,1,#g,nil)
				Duel.Remove(ban,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
function s.batrmvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	if chk==0 then
		return (at==c and a:IsAbleToRemove())
			or (a==c and at~=nil and at:IsAbleToRemove())
	end
	local g=Group.CreateGroup()
	if a:IsRelateToBattle() then g:AddCard(a) end
	if at~=nil and at:IsRelateToBattle() then g:AddCard(at) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.batrmvop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	local g=Group.FromCards(a,at)
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
