--E・HERO ゴッド・ネオス
--Elemental HERO Divine Neos
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Must be Fusion Summoned
	c:AddMustBeFusionSummoned()
	--Fusion Summon materials: 5 "Neos", "Neo Space", "Neo-Spacian", or "HERO" monsters
	--including at least 1 "Neos" or "Neo Space" monster, 1 "Neo-Spacian" monster, and 1 "HERO" monster
	Fusion.AddProcMixRep(c,true,true,s.ffilter,2,2,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_NEOS),aux.FilterBoolFunctionEx(Card.IsSetCard,SET_NEO_SPACIAN),aux.FilterBoolFunctionEx(Card.IsSetCard,SET_HERO))
	--Gains 500 ATK and the banished monster's effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.copycost)
	e1:SetOperation(s.copyop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NEOS,SET_NEO_SPACIAN,SET_HERO}
s.material_setcode={SET_HERO,SET_NEOS,SET_NEO_SPACIAN}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsSetCard(SET_HERO,fc,sumtype,tp) or c:IsSetCard(SET_NEOS,fc,sumtype,tp) or c:IsSetCard(SET_NEO_SPACIAN,fc,sumtype,tp)
end
function s.costfilter(c)
	return c:IsSetCard({SET_NEOS,SET_NEO_SPACIAN,SET_HERO}) and c:IsMonster()
		and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil):GetFirst()
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	Duel.SetTargetParam(tc:GetOriginalCode())
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if c:IsRelateToEffect(e) and c:IsFaceup() and code~=0 then
		--Gains 500 ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		--Gains the banished monster's effects
		local cid=c:CopyEffect(code,RESETS_STANDARD_PHASE_END,1)
		--Reset the copied effect(s) manually
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,1))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		e2:SetCountLimit(1)
		e2:SetLabel(cid)
		--e2:SetLabelObject(e1)
		e2:SetOperation(s.resettop)
		c:RegisterEffect(e2)
	end
end
function s.resettop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	Duel.HintSelection(Group.FromCards(c))
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end