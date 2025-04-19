--プランドリン・アラモード
--Plandolin-a-la-Mode
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160015014,160015012)
	--Can also shuffle monsters from your GY as Fusion Material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_GRAVE,0)
	e1:SetTarget(aux.TargetBoolFunction(s.extrafil_repl_filter))
	e1:SetOperation(s.operation)
	e1:SetLabel(160018042)
	e1:SetLabelObject({s.extrafil_replacement,s.extramat})
	e1:SetValue(function(_,c) return c and c:IsLevelAbove(8) end)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_FUSION,160015051} --Psyquip Fusion
function s.extrafil_repl_filter(c)
	return c:IsMonster() and c:IsAbleToDeck() and c:IsRace(RACE_PSYCHIC)
end
function s.extrafil_replacement(e,tp,mg)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(s.extrafil_repl_filter),tp,LOCATION_GRAVE,0,nil)
end
function s.extramat(c,e,tp)
	return c:IsControler(tp) and e:GetHandler():IsCode(CARD_FUSION,160015051)
end
function s.operation(e,tc,tp,sg)
	local g=tc:GetMaterial()
	local hg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #hg>0 then Duel.HintSelection(hg) end
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
	sg:Clear()
end