--スキャッター・フュージョン
--Scatter Fusion
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Fusion Summon
	local params = {s.fusfilter,aux.FALSE,s.extrafil,nil,nil,s.stage2}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(_,tp) return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end)
	e2:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e2:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e2)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e2)
	--Destroy
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
s.listed_series={0x1047}
function s.fusfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1047) and not c:IsRace(RACE_ROCK)
end
function s.extrafil(e,tp,mg1)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		e:GetHandler():SetCardTarget(tc)
	end
end
function s.desfilter(c,rc)
	return rc:GetCardTarget():IsContains(c)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetCardTargetCount()>0 then
		local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c)
		Duel.Destroy(dg,REASON_EFFECT)
	end
end