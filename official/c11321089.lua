--ガーディアン・キマイラ
--Guardian Chimera
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	local eff=Fusion.AddProcMix(c,true,false,s.ffilter1,s.ffilter2,s.ffilter3)
	if not c:IsStatus(STATUS_COPYING_EFFECT) then
		eff[1]:SetValue(s.matfilter)
	end
	c:AddMustFirstBeFusionSummoned()
	--Keep track of how many materials are used from the hand and field
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	--Draw cards equal to the number of cards used as material from the hand, and if you do, destroy cards your opponent controls equal to the number of cards used as material from the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetLabelObject(e0)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsFusionSummoned() and re and re:IsSpellEffect() end)
	e1:SetTarget(s.drdestg)
	e1:SetOperation(s.drdesop)
	c:RegisterEffect(e1)
	--While "Polymerization" is in your GY, your opponent cannot target this card with card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e) return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,CARD_POLYMERIZATION) end)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_POLYMERIZATION}
function s.ffilter1(c,fc,sumtype,tp,sub,mg,sg)
	return (sumtype==MATERIAL_FUSION or c:IsLocation(LOCATION_HAND))
		and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,sumtype,tp))
end
function s.ffilter2(c,fc,sumtype,tp,sub,mg,sg)
	return (sumtype==MATERIAL_FUSION or c:IsLocation(LOCATION_ONFIELD))
		and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,sumtype,tp))
end
function s.ffilter3(c,fc,sumtype,tp,sub,mg,sg)
	return (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,sumtype,tp))
end
function s.fusfilter(c,code,fc,tp)
	return c:IsSummonCode(fc,SUMMON_TYPE_FUSION,tp,code) and not c:IsHasEffect(511002961)
end
function s.matfilter(c,fc,sub,sub2,mg,sg,tp,contact,sumtype)
	if sumtype&SUMMON_TYPE_FUSION>0 and fc:IsLocation(LOCATION_EXTRA) then
		return c:IsLocation(LOCATION_HAND|LOCATION_ONFIELD) and c:IsControler(tp)
	end
	return true
end
function s.valcheck(e,c)
	local mg=c:GetMaterial()
	local hc=mg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
	local fc=mg:FilterCount(Card.IsLocation,nil,LOCATION_ONFIELD)
	e:SetLabel(hc,fc)
end
function s.drdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	local hc,fc=e:GetLabelObject():GetLabel()
	local dg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return hc>0 and fc>0 and Duel.IsPlayerCanDraw(tp,hc) and #dg>=fc end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,hc)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,#dg,fc,1-tp,LOCATION_ONFIELD)
end
function s.drdesop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local hc,fc=e:GetLabelObject():GetLabel()
	if Duel.Draw(p,hc,REASON_EFFECT)==hc then
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		if #g<fc then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=g:Select(tp,fc,fc,nil)
		if #dg>0 then
			Duel.HintSelection(dg)
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end