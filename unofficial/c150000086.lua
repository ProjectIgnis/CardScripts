--クイズ・フロンティア－エクストラ・ステージ
--Quiz Quest - Extra Stage
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	c:Type(c:Type()|TYPE_FIELD)
end