--機皇神龍トリスケリア
--Meklord Astro Dragon Triskelion
--Scripted by ahtelel
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Must first be Special Summoned (from your hand) by banishing 3 "Meklord" monsters with different names from your GY
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	--Look at your opponent's Extra Deck and equip 1 monster from it to this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	--This card gains ATK equal to the combined ATK of those equipped monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function(e,c) return e:GetHandler():GetEquipGroup():Filter(Card.HasFlagEffect,nil,id):GetSum(Card.GetAttack) end)
	c:RegisterEffect(e2)
	--While equipped with a Synchro Monster, this card can make up to 3 attacks on monsters during each Battle Phase
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e) return e:GetHandler():GetEquipGroup():IsExists(Card.IsOriginalType,1,nil,TYPE_SYNCHRO) end)
	e3:SetValue(2)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MEKLORD}
function s.spcostfilter(c)
	return c:IsSetCard(SET_MEKLORD) and c:IsMonster() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetMZoneCount(tp,sg)>0 and sg:GetClassCount(Card.GetCode)==#sg,sg:GetClassCount(Card.GetCode)~=#sg
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	return #rg>=2 and aux.SelectUnselectGroup(rg,e,tp,3,3,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	local g=aux.SelectUnselectGroup(rg,e,tp,3,3,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end
function s.eqfilter(c,tp)
	return c:CheckUniqueOnField(tp) and c:IsMonster() and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,0,LOCATION_EXTRA,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_EXTRA)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local g=Duel.GetMatchingGroup(s.eqfilter,tp,0,LOCATION_EXTRA,nil,tp)
		if #g==0 then return end
		Duel.ConfirmCards(tp,Duel.GetFieldGroup(tp,0,LOCATION_EXTRA))
		if c:IsFacedown() then return Duel.ShuffleExtra(1-tp) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local ec=g:Select(tp,1,1,nil):GetFirst()
		Duel.ShuffleExtra(1-tp)
		if ec and Duel.Equip(tp,ec,c,true) then
			ec:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
			--Equip limit
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetValue(function(e,_c) return _c==c end)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			ec:RegisterEffect(e1)
		end
	end
end