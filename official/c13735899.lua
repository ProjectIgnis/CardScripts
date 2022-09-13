--ミュステリオンの竜冠
--Mysterion the Dragon Crown
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER),aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON))
	--Cannot be used as Fusion Material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--Decreak ATK by 100 per banished card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,cc) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_REMOVED,0)*-100 end)
	c:RegisterEffect(e1)
	--Banish monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.cfilter(c,e,rc)
	return (rc==c or (c:IsFaceup() and rc:IsOriginalRace(c:GetOriginalRace())))
		and c:IsAbleToRemove() and c:IsCanBeEffectTarget(e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local rc=re:GetHandler()
	if chkc then return eg:IsContains(chkc) and s.cfilter(chkc,e,rc) end
	if chk==0 then return re and re:IsActivated() and re:IsActiveType(TYPE_MONSTER) and rc and eg:IsExists(s.cfilter,1,nil,e,rc) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=eg:FilterSelect(tp,s.cfilter,1,1,nil,e,rc)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local g=Group.FromCards(tc)
		if tc:IsFaceup() then
			g=g+Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsOriginalRace,tc:GetOriginalRace()),tp,LOCATION_MZONE,LOCATION_MZONE,tc)
		end
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end