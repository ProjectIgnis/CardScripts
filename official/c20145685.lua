--エクシーズ・アーマー・フォートレス
--Xyz Armor Fortress
--Sripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon Procedure
	Xyz.AddProcedure(c,nil,5,2,s.xyzfilter,aux.Stringid(id,0),2,s.xyzop)
	--Cannot be used as material for an Xyz Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetCondition(function(e) return e:GetHandler():GetOverlayCount()>0 end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Add "Armored Xyz" cards with different names from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--Double battle damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetCondition(function(e) return e:GetHandler():GetEquipTarget():GetBattleTarget() end)
	e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={SET_ARMORED_XYZ}
function s.xyzfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsRank(3,4) and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	return true
end
function s.thfilter(c)
	return c:IsSetCard(SET_ARMORED_XYZ) and c:IsAbleToHand()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	local rt=math.min(ct,c:GetOverlayCount(),2)
	if chk==0 then return rt>0 and c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local ct=c:RemoveOverlayCard(tp,1,rt,REASON_COST)
	e:SetLabel(ct)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,e:GetLabel(),tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g<ct then return end
	local thg=aux.SelectUnselectGroup(g,e,tp,ct,ct,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	if #thg>0 then
		Duel.SendtoHand(thg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,thg)
	end
end